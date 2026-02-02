// Only works for simple text consisting only
// of the characters of the ascii table from 32 to 126

#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

#define VALID_CHARS 94

typedef
struct {
    char c;
    int i;
} charint_t;

int cmpfunc(const void *a, const void *b) {
    return ( ((charint_t*)a)->i - ((charint_t*)b)->i );
}

typedef
struct node_t {
    int freq;
    char c;
    struct node_t *left;
    struct node_t *right;
} node_t;

void swap_node_t(node_t **a, node_t **b) {
    node_t *tmp = *a;
    *a = *b;
    *b = tmp;
}

typedef
struct {
    int len;
    node_t **array;
} nodelist_t;

node_t* new_node(int freq,
                char c,
                node_t *left,
                node_t *right) {
    node_t* n = malloc(sizeof(node_t));
    n->freq = freq;
    n->c = c;
    n->left = left;
    n->right = right;
    return n;
}

void free_nodelist(nodelist_t l) {
    for ( uint8_t i = 0; i<l.len; ++i) {
        free(l.array[i]);
    }
}

nodelist_t string_to_nodelist(char *s) {

    printf("%s\n", s);

    charint_t occurrences[VALID_CHARS];
    for (uint8_t i = 0; i<VALID_CHARS; ++i) {
        occurrences[i].c = (char)(i+32);
        occurrences[i].i = 0;
    }

    for (char *c = s; *c != '\0'; ++c)
        (occurrences[(*c)-32].i)++;

    qsort(occurrences, VALID_CHARS, sizeof(charint_t), cmpfunc);

    uint8_t i = 0;
    for (;i<VALID_CHARS && occurrences[i].i == 0;++i);

    uint8_t len = VALID_CHARS - i;

    node_t** nodes = malloc(len * sizeof(node_t*));

    assert(nodes != NULL);

    uint8_t node_index = 0;
    for (; i<VALID_CHARS; ++i)
        nodes[node_index++] = new_node(occurrences[i].i,
                                       occurrences[i].c,
                                       NULL,
                                       NULL);

    return (nodelist_t) {
        .array = nodes,
        .len   = len
    };
}

void lshift_nodelist_t(nodelist_t* nl, uint8_t amount) {
    for (uint8_t i = 0; i < (nl->len) - amount; ++i) {
        (nl->array)[i] = (nl->array)[i+amount];
    }
    nl->array[(nl->len) - amount] = NULL;
    (nl->len)-=amount;
}

void print_node(node_t *n) {
    printf("%c - %d\n", n->c, n->freq);
}

void print_nodelist_t(nodelist_t l) {
    for ( uint8_t i = 0; i<l.len && l.array[i] != NULL; ++i) {
        print_node(l.array[i]);
    }
}

int main(int argc, char *argv[]) {

    if (argc < 2) {
        printf("Please provide at least one string for encoding!");
        return 0;
    }

    nodelist_t nl = string_to_nodelist(argv[1]);
    print_nodelist_t(nl);
    swap_node_t(&(nl.array[0]), &(nl.array[2]));
    putchar('\n');
    print_nodelist_t(nl);
    free_nodelist(nl);

    return 0;
}

/*
// Structure for binary tree node
struct Node {
    int data;
    struct Node* left;
    struct Node* right;
};

// Function to create a new binary tree node
struct Node* newNode(int data) {
    struct Node* node = (struct Node*)malloc(sizeof(struct Node));
    node->data = data;
    node->left = NULL;
    node->right = NULL;
    return node;
}

// Function to print DOT representation of binary tree
void printDOT(struct Node* root) {
    if (root == NULL)
        return;

    printf("%d [label=\"%d\"];\n", root->data, root->data);

    if (root->left != NULL) {
        printf("%d -- %d;\n", root->data, root->left->data);
        printDOT(root->left);
    }

    if (root->right != NULL) {
        printf("%d -- %d;\n", root->data, root->right->data);
        printDOT(root->right);
    }
}

int main() {
    struct Node* root = newNode(1);
    root->left = newNode(2);
    root->right = newNode(3);
    root->left->left = newNode(4);
    root->left->right = newNode(5);

    // Print DOT representation of the binary tree
    printf("graph BinaryTree {\n");
    printDOT(root);
    printf("}\n");

    return 0;
}
*/