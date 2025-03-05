import java.util.List;

import java.io.FileInputStream;
import java.io.FileOutputStream;

import org.objectweb.asm.ClassReader;
import org.objectweb.asm.ClassWriter;
import org.objectweb.asm.Opcodes;
import org.objectweb.asm.tree.MethodNode;
import org.objectweb.asm.tree.ClassNode;
import org.objectweb.asm.tree.InsnNode;
import org.objectweb.asm.tree.InsnList;
import org.objectweb.asm.tree.AbstractInsnNode;
import org.objectweb.asm.tree.MethodInsnNode;
import org.objectweb.asm.tree.LocalVariableNode;
import org.objectweb.asm.tree.VarInsnNode;
import org.objectweb.asm.Type;

public class MethodExtractor {

    public static void main(String[] args) throws Exception {
        String className = args[0];

        FileInputStream inputStream = new FileInputStream(className);
        ClassReader classReader = new ClassReader(inputStream);
        ClassNode classNode = new ClassNode(); 
        classReader.accept(classNode, 0); 

        for (MethodNode method : classNode.methods) {
            if (!method.name.equals("<init>")) {
                System.out.println(method.name + method.desc);
            }
        }


    }

}
